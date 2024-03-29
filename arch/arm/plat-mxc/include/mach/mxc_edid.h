/*
 * Copyright 2009-2011 Freescale Semiconductor, Inc. All Rights Reserved.
 */

/*
 * The code contained herein is licensed under the GNU General Public
 * License. You may obtain a copy of the GNU General Public License
 * Version 2 or later at the following locations:
 *
 * http://www.opensource.org/licenses/gpl-license.html
 * http://www.gnu.org/copyleft/gpl.html
 */

/*!
 * @defgroup Framebuffer Framebuffer Driver for SDC and ADC.
 */

/*!
 * @file mxc_edid.h
 *
 * @brief MXC EDID tools
 *
 * @ingroup Framebuffer
 */

#ifndef MXC_EDID_H
#define MXC_EDID_H

#define FB_VMODE_ASPECT_4_3	0x10
#define FB_VMODE_ASPECT_16_9	0x20

struct mxc_edid_cfg {
	bool cea_underscan;
	bool cea_basicaudio;
	bool cea_ycbcr444;
	bool cea_ycbcr422;
	bool hdmi_cap;

	/*VSD*/
	bool vsd_dc_48bit;
	bool vsd_dc_36bit;
	bool vsd_dc_30bit;
	bool vsd_dc_y444;
	bool vsd_dvi_dual;
};

int mxc_edid_var_to_vic(struct fb_var_screeninfo *var);
int mxc_edid_mode_to_vic(const struct fb_videomode *mode);
int mxc_edid_read(struct i2c_adapter *adp, unsigned short addr,
	unsigned char *edid, struct mxc_edid_cfg *cfg, struct fb_info *fbi);

#endif
