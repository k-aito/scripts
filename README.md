# save-restore-tree-of-directory-and-filename

## Methodology for save

The directory tree  must be saved with `save-original-tree.sh` script.

It generates a `./original_tree` file

```
MAIN DIRECTORY NAME
md5sum *./filepath
```

## Methodology for restore

You can define which operation you use for the restore. By default and the safest is hardlink.
The available operations are `move`, `hardlink` and `symlink`.

We generate `./actual_tree` that contains md5sum for the actual directory.
Finally, we read each from the `./original_tree` and try to find the md5sum that in the `./actual_tree`

If we found it, we use the wanted operation on the file.
If not, the script exit with an error message.
