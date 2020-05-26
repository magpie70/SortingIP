
#include"xparameters.h"
#include "xil_io.h"
#include "xscugic.h"

static void myISR();

int main(){
	u32 a[]={5,9,14,62,2,13,47,9,71,55};
	u32 b[10];
	u32 Status;
	XScuGic IntcInstancePtr;
	XScuGic_Config *IntcConfig;

	IntcConfig = XScuGic_LookupConfig(XPAR_SCUGIC_SINGLE_DEVICE_ID);
	if (NULL == IntcConfig) {
			return XST_FAILURE;
	}
	Status = XScuGic_CfgInitialize(&IntcInstancePtr, IntcConfig,IntcConfig->CpuBaseAddress);
	if (Status != XST_SUCCESS) {
			return XST_FAILURE;
	}
	XScuGic_SetPriorityTriggerType(&IntcInstancePtr, XPAR_FABRIC_SORT1_V1_0_0_INTR_INTR, 0xA0, 0x3);
	Status = XScuGic_Connect(&IntcInstancePtr, XPAR_FABRIC_SORT1_V1_0_0_INTR_INTR,(Xil_InterruptHandler)myISR,0);
	if (Status != XST_SUCCESS) {
		return Status;
	}
	XScuGic_Enable(&IntcInstancePtr, XPAR_FABRIC_MERGE_V1_0_0_INTR_INTR);


	Xil_ExceptionInit();
	Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT,(Xil_ExceptionHandler)XScuGic_InterruptHandler,(void *)&IntcInstancePtr);
	Xil_ExceptionEnable();


	for(int i=0;i<10;i++){
		Xil_Out32(XPAR_SORT1_V1_0_0_BASEADDR+0x8,a[i]);
	}


	Xil_Out32(XPAR_SORT1_V1_0_0_BASEADDR,0x1);

	Status = Xil_In32(XPAR_SORT1_V1_0_0_BASEADDR+4);
	while(!Status)
		Status = Xil_In32(XPAR_SORT1_V1_0_0_BASEADDR+4);
	for(int i=0;i<10;i++){
		c[i] = Xil_In32(XPAR_SORT1_V1_0_0_BASEADDR+0xc);
		xil_printf("%d\n\r",c[i]);
	}

	while(1){
		xil_printf("I am working..\n\r");
	}

	return 0;
}

static void myISR(){
	Xil_Out32(XPAR_SORT1_V1_0_0_BASEADDR+4,0x0);
	xil_printf("Got Interrupt\n\r");
	for(int i=0;i<10;i++)
		xil_printf("%d\n\r",Xil_In32(XPAR_MERGE_V1_0_0_BASEADDR+0x8));
}