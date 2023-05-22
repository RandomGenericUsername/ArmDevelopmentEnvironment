#include <stm32f411xe.h>



int main(void)
{
    RCC->AHB1ENR |= 1;
    GPIOA->MODER |= 1 << 10;

    while(1)
    {
        GPIOA->ODR |= 1 << 5;
        for(unsigned int i = 0; i < 1000000; i++);
        GPIOA->ODR &= ~(1 << 5);
    }
    return 0;
}