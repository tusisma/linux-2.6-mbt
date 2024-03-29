/*
 * Copyright (C) 2011 Freescale Semiconductor, Inc. All Rights Reserved.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.

 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.

 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */

#ifndef __MIPI_DSI_H__
#define __MIPI_DSI_H__

#ifdef DEBUG
#define mipi_dbg(fmt, ...) printk(KERN_DEBUG pr_fmt(fmt), ##__VA_ARGS__)
#else
#define mipi_dbg(fmt, ...)
#endif

#define	DSI_CMD_BUF_MAXSIZE         (32)

/* DPI interface pixel color coding map */
enum mipi_dsi_dpi_fmt {
	MIPI_RGB565_PACKED = 0,
	MIPI_RGB565_LOOSELY,
	MIPI_RGB565_CONFIG3,
	MIPI_RGB666_PACKED,
	MIPI_RGB666_LOOSELY,
	MIPI_RGB888,
};

struct mipi_lcd_config {
	u32				virtual_ch;
	u32				data_lane_num;
	/* device max DPHY clock in MHz unit */
	u32				max_phy_clk;
	enum mipi_dsi_dpi_fmt		dpi_fmt;
};

struct mipi_dsi_info;
struct mipi_dsi_lcd_callback {
	/* callback for lcd panel operation */
	void (*get_mipi_lcd_videomode)(struct fb_videomode **, int *,
			struct mipi_lcd_config **);
	int  (*mipi_lcd_setup)(struct mipi_dsi_info *);

};

struct mipi_dsi_match_lcd {
	char *lcd_panel;
	struct mipi_dsi_lcd_callback lcd_callback;
};

/* driver private data */
struct mipi_dsi_info {
	int				ipu_id;
	int				disp_id;
	char				*lcd_panel;
	int				irq;
	u32				dphy_pll_config;
	struct clk			*dphy_clk;
	void __iomem			*mmio_base;
	struct platform_device		*pdev;
	struct mxc_dispdrv_entry	*disp_mipi;
	struct notifier_block		nb;
	struct  fb_videomode		*mode;
	struct  mipi_lcd_config		*lcd_config;
	/* board related power control */
	struct backlight_device		*bl;
	struct regulator		*io_regulator;
	struct regulator		*core_regulator;
	struct regulator		*analog_regulator;
	int				io_volt;
	int				core_volt;
	int				analog_volt;
	void (*reset) (void);
	void (*lcd_power)(int);
	void (*backlight_power)(int);
	/* callback for lcd panel operation */
	struct mipi_dsi_lcd_callback	*lcd_callback;
};

int mipi_dsi_pkt_write(struct mipi_dsi_info *mipi,
				u8 data_type, const u32 *buf, int len);
int mipi_dsi_pkt_read(struct mipi_dsi_info *mipi,
				u8 data_type, u32 *buf, int len);
int mipi_dsi_dcs_cmd(struct mipi_dsi_info *mipi,
				u8 cmd, const u32 *param, int num);

#ifdef CONFIG_FB_MXC_TRULY_WVGA_SYNC_PANEL
void mipid_hx8369_get_lcd_videomode(struct fb_videomode **mode, int *size,
		struct mipi_lcd_config **data);
int mipid_hx8369_lcd_setup(struct mipi_dsi_info *);
#endif

#ifndef CONFIG_FB_MXC_TRULY_WVGA_SYNC_PANEL
#error "Please configure MIPI LCD panel, we cannot find one!"
#endif

#endif
