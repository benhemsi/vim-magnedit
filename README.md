# magnedit

Magnedit brings the magical, long-range powers of magnets to editing in vim!

This lightweight plugin has a number of very handy long-range editing shortcuts with sensible mappings.

It aims to offer all the line and paragraph editing commands you could want without having to move your cursor.

The table below shows the default mappings and there really isn't anything else to it!

### Simple editing

| Mapping | Command |
| ------- | ------- |
| \<count\>dJ             | Delete line \<count\> below current line |
| \<count\>dK             | Delete line \<count\> above current line |
| \<count\>d]             | Delete paragraph \<count\> below current line |
| \<count\>d[             | Delete paragraph \<count\> above current line |
| \<count\>yJ             | Yank line \<count\> below current line |
| \<count\>yK             | Yank line \<count\> above current line |
| \<count\>y]             | Yank paragraph \<count\> below current line |
| \<count\>y[             | Yank paragraph \<count\> above current line |
| \<count\>\<leader\>o    | Insert empty line \<count\> below current line |
| \<count\>\<leader\>O    | Insert empty line \<count\> above current line |
| \<count\>\<leader\>p    | Paste \<count\> below current line |
| \<count\>\<leader\>P    | Paste \<count\> above current line |
| \<count\>gcJ            | Toggle commentary on line \<count\> below current line (requires vim-commentary) |
| \<count\>gcK            | Toggle Commentary on line \<count\> above current line (requires vim-commentary) |
| \<count\>gc]            | Toggle Commentary on paragraph \<count\> below current line (requires vim-commentary) |
| \<count\>gc[            | Toggle Commentary on paragraph \<count\> above current line (requires vim-commentary) |

### Mappings for moving text

| Mapping | Command |
| ------- | ------- |
| \<count\>mJ             | Move line \<count\> below current line to current location 
| \<count\>mK             | Move line \<count\> above current line to current location  
| \<count\>m]             | Move paragraph \<count\> below current line to current location 
| \<count\>m[             | Move paragraph \<count\> above current line to current location 
| \<count\>\<leader\>mJ   | Move current line \<count\> lines downwards
| \<count\>\<leader\>mK   | Move current line \<count\> lines upwards
| \<count\>\<leader\>m]   | Move current paragraph \<count\> lines downwards
| \<count\>\<leader\>m[   | Move current paragraph \<count\> lines upwards
| \<count\>\<leader\>mJ   | Move current visual selection \<count\> lines downwards
| \<count\>\<leader\>mK   | Move current visual selection \<count\> lines upwards

### Mappings for copying text

| Mapping | Command |
| ------- | ------- |
| \<count\>cJ             | Copy line \<count\> below current line to current location 
| \<count\>cK             | Copy line \<count\> above current line to current location  
| \<count\>c]             | Copy paragraph \<count\> below current line to current location 
| \<count\>c[             | Copy paragraph \<count\> above current line to current location 
| \<count\>\<leader\>cJ   | Copy current line \<count\> lines downwards                      
| \<count\>\<leader\>cK   | Copy current line \<count\> lines upwards
| \<count\>\<leader\>c]   | Copy current paragraph \<count\> lines downwards
| \<count\>\<leader\>c[   | Copy current paragraph \<count\> lines upwards
| \<count\>\<leader\>cJ   | Copy current visual selection \<count\> lines downwards
| \<count\>\<leader\>cK   | Copy current visual selection \<count\> lines upwards

### Installation


