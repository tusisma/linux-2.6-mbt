#
# OTG infrastructure and transceiver drivers
#

ccflags-$(CONFIG_USB_DEBUG)		:= -DDEBUG
ccflags-$(CONFIG_USB_GADGET_DEBUG)	+= -DDEBUG

# infrastructure
obj-$(CONFIG_USB_OTG_UTILS)	+= otg.o

# transceiver drivers
obj-$(CONFIG_USB_GPIO_VBUS)	+= gpio_vbus.o
obj-$(CONFIG_ISP1301_OMAP)	+= isp1301_omap.o
obj-$(CONFIG_TWL4030_USB)	+= twl4030-usb.o
obj-$(CONFIG_TWL6030_USB)	+= twl6030-usb.o
obj-$(CONFIG_USB_LANGWELL_OTG)	+= langwell_otg.o
obj-$(CONFIG_NOP_USB_XCEIV)	+= nop-usb-xceiv.o
obj-$(CONFIG_USB_ULPI)		+= ulpi.o
obj-$(CONFIG_USB_MSM_OTG_72K)	+= msm72k_otg.o
obj-$(CONFIG_AB8500_USB)	+= ab8500-usb.o
fsl_otg_arc-objs		:= fsl_otg.o otg_fsm.o
obj-$(CONFIG_MXC_OTG)		+= fsl_otg_arc.o
