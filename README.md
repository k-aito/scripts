# save-original-tree.sh

## Methodology for save

The directory tree  must be saved with `save-original-tree.sh` script.

It generates a `./original_tree` file

```
MAIN DIRECTORY NAME
md5sum *./filepath
```

# restore-original-tree.sh

## Methodology for restore

You can define which operation you use for the restore. By default, the safest is hardlink.
The available operations are `move`, `hardlink` and `symlink`.

We generate `./actual_tree` that contains md5sum for the actual directory.
Finally, we read each from the `./original_tree` and try to find the md5sum that is in the `./actual_tree`

If we find it, we use the wanted operation on the file.
If not, the script exits with an error message.

# mkvextract-all.sh

## Methodology

It extracts all the tracks and attachments. It is possible to define in WHITELIST_CODEC_ID which types of tracks we want to extract.

That is achieved by parsing the result of `mkvinfo`. The CODEC_ID is manually defined in a switch to avoid any issues.
If the CODEC_ID is not recognized, it is possible to add it to the switch with the proper file extension name.

There are also commented lines that can be used if `mkvtoolnix` is installed as a flatpak.
