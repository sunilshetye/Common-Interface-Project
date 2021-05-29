#!/usr/bin/awk -f

BEGIN {
    STDERR = "/dev/stderr";
    PRINTCATEGORIESCSV = 1;
    CATEGORIESCSV = "categories.csv";
    categoryid = 0;
    PRINTCATEGORYBLOCKSCSV = 1;
    CATEGORYBLOCKSCSV = "categories-blocks.csv";
    PRINTBLOCKSCSV = 0;
    BLOCKSCSV = "blocks.csv";
    blockid = 0;
    PRINTBLOCKPORTSCSV = 1;
    BLOCKPORTSCSV = "blocks-ports.csv";
    blockportid = 0;
    PRINTMINMAXCSV = 0;
    MINMAXCSV = "blocks-ports-min-max.csv";
}

BEGINFILE {
    category = gensub("(.*/)?([^/]*)\\.lib$", "\\2", "g", FILENAME);
    categoryid++;
    blockcount = 0;
}

/^DEF / {
    delete blockports;
    block = $2;
    idx = block;
    duplicateblock = idx in blocks;
    last_port_order = 0;
    if (!duplicateblock) {
        blockid++;
        blockcount++;
        max_port_order = -1;
        block_class = $3;
        blocks[idx] = $0;
        if (PRINTCATEGORYBLOCKSCSV) {
            printf "%s\t%s\t%s\t%s\n", blockid, category, block, block_class > CATEGORYBLOCKSCSV;
        }
        if (PRINTBLOCKSCSV) {
            printf "%s\t%s\t%s\n", blockid, block, block_class > BLOCKSCSV;
        }
    } else {
        if (blocks[idx] == $0) {
            printf "duplicate block: %s\n", block > STDERR;
        } else {
            printf "not a duplicate block: %s: %s and %s\n", block, blocks[idx], $0 > STDERR;
        }
    }
}

/^X / {
    if (duplicateblock)
        next;
    port_name = $2;
    port_number = $3;
    if (port_number ~ /^[0-9]+$/) {
        port_order = port_number;
    } else {
        port_order = last_port_order + 1;
    }
    last_port_order = port_order;
    port_orientation = $7;
    port_part = $10;
    port_dmg = $11;
    port_type = $12;
    idx = block SUBSEP port_order;
    if (!(idx in ports)) {
        ports[idx] = $0;
        blockports[port_order] = sprintf("%s\t%s\t%s\t%s\t%s\t%s\n", block, port_number, port_name, port_order, port_type, port_orientation);
        if (max_port_order < port_order) {
            max_port_order = port_order;
        }
        if (block in minports) {
            if (minports[block] > port_order) {
                minports[block] = port_order;
            } else if (maxports[block] < port_order) {
                maxports[block] = port_order;
            }
        } else {
            minports[block] = port_order;
            maxports[block] = port_order;
        }
    } else {
        if (port_part == "2" || port_part == "3" || port_part == "4" || port_dmg == "2") {
            ;
        } else if (ports[idx] == $0) {
            printf "duplicate port: %s %s %s %s\n", block, port_number, port_part, port_dmg > STDERR;
        } else {
            printf "not a duplicate port: %s %s %s %s: %s and %s\n", block, port_number, port_part, port_dmg, ports[idx], $0 > STDERR;
        }
    }
}

/^ENDDEF/ {
    if (PRINTBLOCKPORTSCSV) {
        for (i = 0; i <= max_port_order; i++) {
            if (i in blockports) {
                blockportid++;
                printf "%s\t%s", blockportid, blockports[i] > BLOCKPORTSCSV;
            }
        }
    }
    block = "";
}

ENDFILE {
    if (PRINTCATEGORIESCSV) {
        printf "%s\t%s\t%s\t%s\n", categoryid, category, categoryid, blockcount > CATEGORIESCSV;
    }

    category = "";
}

END {
    if (PRINTMINMAXCSV) {
        for (block in minports) {
            printf "%s\t%s\t%s\n", block, minports[block], maxports[block] > MINMAXCSV;
        }
    }
}
