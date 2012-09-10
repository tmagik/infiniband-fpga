

                    Core Name: Xilinx Virtex-5 GTX Transceiver Wizard
                    Version: 1.5
                    Release Date: September 19, 2008


================================================================================

This document contains the following sections:

1. Introduction
2. New Features
3. Resolved Issues
4. Known Issues
5. Technical Support
6. Core Release History

================================================================================

1. INTRODUCTION

For the most recent updates to the IP installation instructions for this core,
please go to:

   http://www.xilinx.com/ipcenter/coregen/ip_update_install_instructions.htm


For system requirements:

   http://www.xilinx.com/ipcenter/coregen/ip_update_system_requirements.htm



This file contains release notes for the Xilinx Virtex-5 FPGA GTX
Transceiver Wizard v1.5. For the latest core updates, see the product
page at:

   http://www.xilinx.com/products/ipcenter/V5_GTX_Wizard.htm


2. NEW FEATURES

   - Support for the new TXT Family (TX150T-1156/1759, TX240T-1759) -
     TXT devices have two columns of Tiles, left column and right column.
     When a TXT device is selected in the CORE Generator project options,
     Page 1 of the Wizard shows a Tile Column selection box with 'left' and
     'right' choices. Only one column can be selected at a time. If a design
     uses Tiles from both columns, run the Wizard twice, once with right column
     selection and once with left column selection. Merge these two designs.

     Note on Tile coordinates: In TXT devices, the left column has the X0
     indices and right column has the X1 indices. In FXT devices, there is only
     one column on the right with X0 indices. This difference should be noted
     when porting designs from the FXT to the TXT family.
   
   - TX Phase Alignment Updates -
     New radio button for "Lane-to-lane deskew" mode on Page 4 of the Wizard
     under TX PCS/PMA Alignment. Select this mode if your application needs to
     minimize Lane-to-lane TX Skew using the TX Phase Alignment circuit. In
     this mode, the Wizard outputs a new TX_SYNC module that implements the
     Phase Alignment procedure described in UG198 Section 1, Chapter 6 -
     "TX Buffering, Phase Alignment, and TX Skew Reduction".
     
     The Wizard generates a TX_SYNC module for each tile selected. This module
     performs Phase Alignment for both GTX0 and GTX1 in a tile. This implies a
     restriction that "Lane-to-lane deskew" mode must be selected on both GTX0
     and GTX1, unless one of them in unused. "Lane-to-lane deskew" mode on one
     GTX and "Enable TX Buffer" or "Bypass TX Buffer" mode on the other GTX is
     not supported.

     The Phase Alignment procedure involves DRP operations on the attributes
     TX_XCLK_SEL0/1. The TX_SYNC module provides an interface for User DRP
     operations. User DRP operations are blocked when the module is accessing
     DRP for Phase Alignment related operations.

     Note: TX Buffer Bypass is an advanced feature and is not recommended
     for normal operation.


3. RESOLVED ISSUES

   - CR#476618 - TX/RXELECIDLE Pins brought out to example_mgt_top level for
                 XAUI Protocol template

   - CR#476779 - RXDATA_OUT is assigned incorrectly in the tile wrapper file
                 when RX interface is set to 20 bit, Decoding is set to "None",
                 and TX interface is set to 16 bit, Encoding to 8B10B


4. KNOWN ISSUES
   
   - For some of the designs, timing closure at fabric rates of 312.5 MHz and
     higher might require significant effort. For best results, use a
     16/20/32/40 bit interface for line rates higher than 2.5 Gbps.

   The most recent information, including known issues, workarounds, and
   resolutions for this version is provided in the release notes Answer Record
   for the ISE 10.1 IP Update at

   http://www.xilinx.com/support/documentation/user_guides/xtp025.pdf


5. TECHNICAL SUPPORT

   To obtain technical support, create a WebCase at www.xilinx.com/support.
   Questions are routed to a team with expertise using this product.

   Xilinx provides technical support for use of this product when used
   according to the guidelines described in the core documentation, and
   cannot guarantee timing, functionality, or support of this product for
   designs that do not follow specified guidelines.


6. CORE RELEASE HISTORY

Date        By            Version      Description
================================================================================
09/18/2008  Xilinx, Inc.  1.5          TXT support, Lane-to-lane Deskew module
06/27/2008  Xilinx, Inc.  1.4          OBSAI, PCIE Gen2, OOBDETECT_THRESHOLD update
04/25/2008  Xilinx, Inc.  1.3          Optimized CDR attributes
03/24/2008  Xilinx, Inc.  1.2          Initial release
================================================================================


(c) 2008 Xilinx, Inc. All Rights Reserved.


XILINX, the Xilinx logo, and other designated brands included herein are
trademarks of Xilinx, Inc. All other trademarks are the property of their
respective owners.

Xilinx is disclosing this user guide, manual, release note, and/or
specification (the Documentation) to you solely for use in the development
of designs to operate with Xilinx hardware devices. You may not reproduce,
distribute, republish, download, display, post, or transmit the Documentation
in any form or by any means including, but not limited to, electronic,
mechanical, photocopying, recording, or otherwise, without the prior written
consent of Xilinx. Xilinx expressly disclaims any liability arising out of
your use of the Documentation.  Xilinx reserves the right, at its sole
discretion, to change the Documentation without notice at any time. Xilinx
assumes no obligation to correct any errors contained in the Documentation, or
to advise you of any corrections or updates. Xilinx expressly disclaims any
liability in connection with technical support or assistance that may be
provided to you in connection with the information. THE DOCUMENTATION IS
DISCLOSED TO YOU AS-IS WITH NO WARRANTY OF ANY KIND. XILINX MAKES NO
OTHER WARRANTIES, WHETHER EXPRESS, IMPLIED, OR STATUTORY, REGARDING THE
DOCUMENTATION, INCLUDING ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
PARTICULAR PURPOSE, OR NONINFRINGEMENT OF THIRD-PARTY RIGHTS. IN NO EVENT
WILL XILINX BE LIABLE FOR ANY CONSEQUENTIAL, INDIRECT, EXEMPLARY, SPECIAL, OR
INCIDENTAL DAMAGES, INCLUDING ANY LOSS OF DATA OR LOST PROFITS, ARISING FROM
YOUR USE OF THE DOCUMENTATION.
