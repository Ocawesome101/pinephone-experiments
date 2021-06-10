#include <stdio.h>
#include <linux/input.h>

int main() {
  printf("size of input_event: %d\n", sizeof(struct input_event));
  printf("size of timeval: %d\n", sizeof(struct timeval));
}
