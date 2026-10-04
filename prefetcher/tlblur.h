#ifndef TLBLUR_H
#define TLBLUR_H

#include <sgx_trts_aex.h>

sgx_status_t tlblur_enable(uint64_t vtlb_size);
sgx_status_t tlblur_disable(void);

#endif // TLBLUR_H
