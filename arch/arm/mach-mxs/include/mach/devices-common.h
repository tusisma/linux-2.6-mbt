/*
 * Copyright (C) 2009-2010 Pengutronix
 * Uwe Kleine-Koenig <u.kleine-koenig@pengutronix.de>
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License version 2 as published by the
 * Free Software Foundation.
 */
#include <linux/kernel.h>
#include <linux/platform_device.h>
#include <linux/init.h>
#include <linux/amba/bus.h>

struct platform_device *mxs_add_platform_device_dmamask(
		const char *name, int id,
		const struct resource *res, unsigned int num_resources,
		const void *data, size_t size_data, u64 dmamask);

static inline struct platform_device *mxs_add_platform_device(
		const char *name, int id,
		const struct resource *res, unsigned int num_resources,
		const void *data, size_t size_data)
{
	return mxs_add_platform_device_dmamask(
			name, id, res, num_resources, data, size_data, 0);
}

int __init mxs_add_amba_device(const struct amba_device *dev);

/* duart */
int __init mxs_add_duart(const struct amba_device *dev);

/* auart */
struct mxs_auart_data {
	int id;
	resource_size_t iobase;
	resource_size_t iosize;
	resource_size_t irq;
};
struct platform_device *__init mxs_add_auart(
		const struct mxs_auart_data *data);

/* fec */
#include <linux/fec.h>
struct mxs_fec_data {
	int id;
	resource_size_t iobase;
	resource_size_t iosize;
	resource_size_t irq;
};
struct platform_device *__init mxs_add_fec(
		const struct mxs_fec_data *data,
		const struct fec_platform_data *pdata);

/* flexcan */
#include <linux/can/platform/flexcan.h>
struct mxs_flexcan_data {
	int id;
	resource_size_t iobase;
	resource_size_t iosize;
	resource_size_t irq;
};
struct platform_device *__init mxs_add_flexcan(
		const struct mxs_flexcan_data *data,
		const struct flexcan_platform_data *pdata);

/* gpmi-nfc */
#include <mach/gpmi-nfc.h>
struct mxs_gpmi_nfc_data {
	const char *devid;
	const struct resource res[RES_SIZE];
};
struct platform_device *__init
mxs_add_gpmi_nfc(const struct gpmi_nfc_platform_data *pdata,
		const struct mxs_gpmi_nfc_data *data);

/* i2c */
struct mxs_i2c_data {
	int id;
	resource_size_t iobase;
	resource_size_t errirq;
	resource_size_t dmairq;
};
struct platform_device * __init mxs_add_mxs_i2c(const struct mxs_i2c_data *data);

/* pwm */
struct platform_device *__init mxs_add_mxs_pwm(
		resource_size_t iobase, int id);
