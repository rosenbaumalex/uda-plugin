/*
** Copyright (C) Mellanox Technologies Ltd. 2001-2011.  ALL RIGHTS RESERVED.
**
** This software product is a proprietary product of Mellanox Technologies Ltd.
** (the "Company") and all right, title, and interest in and to the software product,
** including all associated intellectual property rights, are and shall
** remain exclusively with the Company.
**
** This software product is governed by the End User License Agreement
** provided with the software product.
**
*/

#ifndef  RDMA_COMMON_HEADER 
#define  RDMA_COMMON_HEADER 1

#include <rdma/rdma_cma.h>

#include "NetlevComm.h"

#define NETLEV_LISTENER_BACKLOG (32)
#define RDMA_DEFAULT_RNR_RETRY  (7)
#define NETLEV_MEM_ACCESS_PERMISSION (IBV_ACCESS_LOCAL_WRITE|IBV_ACCESS_REMOTE_WRITE)

typedef struct connreq_data{
    uint32_t qp;
    uint32_t credits;
    unsigned int mem_rkey;
    unsigned int rdma_mem_rkey;
} connreq_data_t;

typedef enum {
    MSG_NOOP   = 0x0,
    MSG_RTS    = 0x01,
    MSG_CTS    = 0x02, /* Not used yet. It meant to trigger RDMA Read */
    MSG_INLINE = 0x04,
    MSG_DONE   = 0x08
} msg_type_t;

typedef enum {
    SEND_WQE_AVAIL = 0x0, /* Free */
    SEND_WQE_INIT  = 0x1, /* claimed for usage */
    SEND_WQE_POST  = 0x2, /* posted for send/recv data */
    SEND_WQE_COMP  = 0x4, /* send completed */
    SEND_WQE_ARRV  = 0x8, /* data arrived*/
    SEND_WQE_DONE  = 0x10 /* ready to return into free list */
} send_wqe_state_t ;

typedef enum {
    RECV_WQE_AVAIL = 0x10, /* Free */
    RECV_WQE_INIT  = 0x11, /* claimed for usage */
    RECV_WQE_POST  = 0x12, /* posted for send/recv data */
    RECV_WQE_COMP  = 0x14, /* data completed */
    RECV_WQE_DONE  = 0x18  /* ready to return into free list */
} recv_wqe_state_t ;

struct netlev_conn;
struct shuffle_req;

typedef struct hdr_header {
    uint8_t   type;                                    
    uint8_t   credits;  /* credits to the peer */      
    uint16_t  padding; 
    uint32_t  tot_len;  /* reserved for matching */
    uint64_t  src_wqe;  /* for fast lookup of request */
} hdr_header_t;

typedef struct netlev_wqe {
    struct list_head         list;
    union {
        struct ibv_recv_wr   rr;
        struct ibv_send_wr   sr;
    } desc;
    struct ibv_sge           sge;
    struct netlev_conn      *conn;

    volatile int             state;
    char                    *data;
    struct shuffle_req      *shreq;
    void                    *context;/*use as a pointer 
                                        pointing to the 
                                        chunk at servier side.
                                       */
    //uint64_t                chunk;    
} netlev_wqe_t;

/* device memory for send/receive */
typedef struct netlev_mem {
    struct ibv_mr *mr;   
    netlev_wqe_t  *wqe_start;     
    void          *wqe_buff_start;     
    int            count;   /* number of netlev_wqes in region  */
} netlev_mem_t;

/* memory for rdma operation */
typedef struct netlev_rdma_mem {
    struct ibv_mr       *mr;   
    unsigned long       total_size;
    void                *buf_start;
} netlev_rdma_mem_t;


typedef struct netlev_dev {
    struct ibv_context       *ibv_ctx;
    struct ibv_pd            *pd;
    struct ibv_cq            *cq;
    struct ibv_comp_channel  *cq_channel;
    netlev_mem_t             *mem;
    netlev_rdma_mem_t        *rdma_mem;

    struct list_head          list;     /* for device list*/
    struct list_head          wqe_list; /* wqes for this device*/
    pthread_mutex_t           lock;
    uint32_t                  cqe_num;
    uint32_t                  max_sge;
    uint32_t                  max_wr;
} netlev_dev_t;

typedef enum {
    NETLEV_CONN_INIT  = 0x0,
    NETLEV_CONN_RTR   = 0x1,
    NETLEV_CONN_RTS   = 0x2,
    NETLEV_CONN_READY = 0x4,
} conn_state_t;

typedef struct netlev_conn
{
    struct netlev_dev  *dev;
    struct rdma_cm_id  *cm_id;
    struct ibv_qp      *qp_hndl;
    struct ibv_sge     *sg_array; /* for rdma write */

    struct list_head    backlog;
    struct list_head    list;

    uint32_t            credits;   /* remaining credits */
    uint32_t            returning; /* returning credits */

    pthread_mutex_t     lock;
    connreq_data_t      peerinfo;

    unsigned long       peerIPAddr;
    unsigned int        peerPort;
    unsigned int        state;
} netlev_conn_t;

int netlev_dealloc_mem(struct netlev_dev *dev, netlev_mem_t *mem);
int netlev_dealloc_rdma_mem(struct netlev_dev *dev);
int netlev_init_mem(struct netlev_dev *dev);
int netlev_dev_init(struct netlev_dev *dev);
void netlev_dev_release(struct netlev_dev *dev);

struct netlev_dev *
netlev_dev_find(struct rdma_cm_id *cm_id, 
                struct list_head *head);

void netlev_conn_free(netlev_conn_t *conn);

struct netlev_conn *
netlev_conn_alloc(struct netlev_dev *dev, 
                  struct rdma_cm_id *cm_id);

struct netlev_conn * 
netlev_find_conn_by_qp (uint32_t qp_num, struct list_head *q);

struct netlev_conn * 
netlev_find_conn_by_ip(unsigned long ipaddr, struct list_head *q);

void init_wqe_rdmaw(netlev_wqe_t *wqe, int len,
                    void *laddr, uint32_t lkey,
                    void *raddr, uint32_t rkey);

void init_wqe_send (netlev_wqe_t *wqe, unsigned int len, 
                    uint32_t lkey, netlev_conn_t *conn);
void init_wqe_recv (netlev_wqe_t *wqe, unsigned int len, 
                    uint32_t lkey, netlev_conn_t *conn);
netlev_wqe_t * get_netlev_wqe (struct list_head *head);
void release_netlev_wqe (netlev_wqe_t * wqe, struct list_head *head);

void set_wqe_addr_key(netlev_wqe_t * wqe, 
                      int len,
                      void *local_addr,
                      uint32_t lkey,
                      void *remote_addr,
                      uint32_t rkey);

typedef struct netlev_ctx {
    struct list_head           hdr_event_list;
    struct list_head           hdr_dev_list;
    struct list_head           hdr_conn_list;
    int                        epoll_fd;
    pthread_mutex_t            lock;

    struct rdma_event_channel *cm_channel;
    struct rdma_cm_id         *cm_id;
} netlev_ctx_t;

/* return a completion channel, and a QP */
struct netlev_conn *
netlev_init_conn(struct rdma_cm_event *event,
                 struct netlev_dev *dev);

struct netlev_conn *
netlev_conn_established(struct rdma_cm_event *event, struct list_head *head);

struct netlev_conn *
netlev_disconnect(struct rdma_cm_event *ev, struct list_head *head);

int 
netlev_send_noop(struct netlev_conn *conn);

int netlev_post_send(void *buff, int bytes, uint64_t wqeid,
                     netlev_wqe_t *wqe, netlev_conn_t *conn);

int netlev_init_rdma_mem(void *, unsigned long total_size,
                         netlev_dev_t *dev);

const char* netlev_stropcode(int opcode);

#endif

/*
 * Local variables:
 *  c-indent-level: 4
 *  c-basic-offset: 4
 * End:
 *
 * vim: ts=4 sw=4 hlsearch cindent expandtab 
 */