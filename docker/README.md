This directory contains custom images necessary to run the environment.

Starting with kali, which contains the packages:
- 1
- 2
- 3

If an image is modified, the following need to be done:

1. Go to the image directory, like: /docker/kali-custom
2. Execute the command: docker build -t <image-name> .
    Where <image-name> is the name the image will have, like kali-custom
3. To ensure it has been created, use the command: docker images