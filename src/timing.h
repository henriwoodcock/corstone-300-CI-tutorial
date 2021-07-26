#include <stdio.h>

#define KIN1_DWT_CONTROL (*((volatile uint32_t*)0xE0001000))

// DWT Control register.
#define KIN1_DWT_CYCCNTENA_BIT (1UL << 0)

// CYCCNTENA bit in DWT_CONTROL register.
#define KIN1_DWT_CYCCNT (*((volatile uint32_t*)0xE0001004))

// DWT Cycle Counter register.
#define KIN1_DEMCR (*((volatile uint32_t*)0xE000EDFC))

// DEMCR: Debug Exception and Monitor Control Register.
#define KIN1_TRCENA_BIT (1UL << 24)

// Trace enable bit in DEMCR register.
#define KIN1_LAR (*((volatile uint32_t*)0xE0001FB0))

// Unlock access to DWT (ITM, etc.)registers.
#define KIN1_UnlockAccessToDWT() KIN1_LAR = 0xC5ACCE55;

// TRCENA: Enable trace and debug block DEMCR (Debug Exception and Monitor
// Control Register.
#define KIN1_InitCycleCounter() KIN1_DEMCR |= KIN1_TRCENA_BIT

#define KIN1_ResetCycleCounter() KIN1_DWT_CYCCNT = 0
#define KIN1_EnableCycleCounter() KIN1_DWT_CONTROL |= KIN1_DWT_CYCCNTENA_BIT
#define KIN1_DisableCycleCounter() KIN1_DWT_CONTROL &= ~KIN1_DWT_CYCCNTENA_BIT
#define KIN1_GetCycleCounter() KIN1_DWT_CYCCNT


#define kClocksPerSecond 25e6

int32_t ticks_per_second() { return kClocksPerSecond; }

int32_t GetCurrentTimeTicks() { return KIN1_GetCycleCounter(); }

int32_t TicksToMs(int32_t ticks) {
  return (int32_t)(1000.0f * (float)(ticks) / (float)(ticks_per_second()));
}
