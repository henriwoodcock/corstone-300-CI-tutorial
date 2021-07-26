#include <stdio.h>
#include <assert.h>

#include "ethos_u_core_platform/targets/corstone-300/uart.h"
#include "arm_math.h"

#include "model_settings.h"
#include "timing.h"

arm_gaussian_naive_bayes_instance_f32 S;
float32_t in[2];

/* Result of the classifier */
float32_t result[NB_OF_CLASSES];
float32_t temp[NB_OF_CLASSES];
float32_t maxProba;
uint32_t index;

void uart_init(void);

void setup(void) {
  // Initialize corstone-300 uart
  uart_init();
  // Initialize tick timing functions
  KIN1_UnlockAccessToDWT();
  KIN1_InitCycleCounter();
  KIN1_ResetCycleCounter();
  KIN1_EnableCycleCounter();

  // add parameters to naive bayes instance
  S.vectorDimension = VECTOR_DIMENSION;
  S.numberOfClasses = NB_OF_CLASSES;
  S.theta = theta;
  S.sigma = sigma;
  S.classPriors = classPriors;
  S.epsilon=EPSILON;
}

void CheckNumberOfClasses(void) {
  assert(3 == NB_OF_CLASSES);
}

void CheckXDimension(void) {
  assert(2 == VECTOR_DIMENSION);
}

void CheckIndexZero(void) {
  in[0] = 4.9f;
  in[1] = 3.1f;

  index = arm_gaussian_naive_bayes_predict_f32(&S, in, result,temp);
  maxProba = result[index];
  assert(0 == index);
}

void CheckIndexOne(void) {
  in[0] = 5.7f;
  in[1] = 2.6f;

  index = arm_gaussian_naive_bayes_predict_f32(&S, in, result,temp);
  maxProba = result[index];
  assert(1 == index);
}

void CheckIndexTwo(void) {
  in[0] = 7.7f;
  in[1] = 3.0f;

  index = arm_gaussian_naive_bayes_predict_f32(&S, in, result,temp);
  maxProba = result[index];
  assert(2 == index);
}

void CheckInferenceTime(void) {
  in[0] = 7.7f;
  in[1] = 3.0f;

  const int32_t start_ticks = GetCurrentTimeTicks();
  for (int i=0; i<100; i++) {
    index = arm_gaussian_naive_bayes_predict_f32(&S, in, result, temp);
  }
  const int32_t end_ticks = GetCurrentTimeTicks();
  const int32_t ticks_taken = end_ticks - start_ticks;
  const int32_t time_in_ms = TicksToMs(ticks_taken / 100);
  assert(0 >= time_in_ms);
}

int main(void) {

  // intialize uart and naive bayes
  setup();

  // run example asserts
  printf("Testing number of model classes.\n");
  CheckNumberOfClasses();
  printf("Testing model input dimension.\n");
  CheckXDimension();
  printf("Testing model output on class 0 example.\n");
  CheckIndexZero();
  printf("Testing model output on class 1 example.\n");
  CheckIndexOne();
  printf("Testing model output on class 2 example.\n");
  CheckIndexTwo();
  printf("Checking inference time\n");
  CheckInferenceTime();

  printf("ALL TESTS PASSED\n");

  return 0;
}
