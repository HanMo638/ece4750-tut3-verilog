// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See VRegIncr_noparam.h for the primary calling header

#include "VRegIncr_noparam__pch.h"
#include "VRegIncr_noparam__Syms.h"
#include "VRegIncr_noparam___024root.h"

#ifdef VL_DEBUG
VL_ATTR_COLD void VRegIncr_noparam___024root___dump_triggers__act(VRegIncr_noparam___024root* vlSelf);
#endif  // VL_DEBUG

void VRegIncr_noparam___024root___eval_triggers__act(VRegIncr_noparam___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    VRegIncr_noparam__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VRegIncr_noparam___024root___eval_triggers__act\n"); );
    // Body
    vlSelf->__VactTriggered.set(0U, ((IData)(vlSelf->clk) 
                                     & (~ (IData)(vlSelf->__Vtrigprevexpr___TOP__clk__0))));
    vlSelf->__Vtrigprevexpr___TOP__clk__0 = vlSelf->clk;
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        VRegIncr_noparam___024root___dump_triggers__act(vlSelf);
    }
#endif
}
