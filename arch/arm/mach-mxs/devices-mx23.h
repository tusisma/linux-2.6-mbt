/*
 * Copyright (C) 2010 Pengutronix
 * Uwe Kleine-Koenig <u.kleine-koenig@pengutronix.de>
 *
 * Copyright 2010-2011 Freescale Semiconductor, Inc.
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License version 2 as published by the
 * Free Software Foundation.
 */
#include <mach/mx23.h>
#include <mach/devices-common.h>
#include <mach/mxsfb.h>

extern const struct amba_device mx23_duart_device __initconst;
#define mx23_add_duart() \
	mxs_add_duart(&mx23_duart_device)

extern const struct mxs_auart_data mx23_auart_data[] __initconst;
#define mx23_add_auart(id)	mxs_add_auart(&mx23_auart_data[id])
#define mx23_add_auart0()		mx23_add_auart(0)
#define mx23_add_auart1()		mx23_add_auart(1)

extern const struct mxs_gpmi_nfc_data mx23_gpmi_nfc_data __initconst;
#define mx23_add_gpmi_nfc(pdata)	\
	mxs_add_gpmi_nfc(pdata, &mx23_gpmi_nfc_data)

#define mx23_add_mxs_pwm(id)		mxs_add_mxs_pwm(MX23_PWM_BASE_ADDR, id)

struct platform_device *__init mx23_add_mxsfb(
		const struct mxsfb_platform_data *pdata);
