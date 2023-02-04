all: images
	hugo

server: images
	hugo server --disableFastRender

images:
	@find assets/images/ -type f -name "*.png" -or -name "*.jpg" -or -name "*.gif" | while read i; do \
		if file $$i | grep -q "PNG image data"; then \
			mv -fn $$i `dirname $$i`/`sha256sum $$i | grep -Po '^[a-f0-9]{64}'`.png; \
		fi; \
		if file $$i | grep -q "JPEG image data"; then \
                        mv -fn $$i `dirname $$i`/`sha256sum $$i | grep -Po '^[a-f0-9]{64}'`.jpg; \
                fi; \
		if file $$i | grep -q "GIF image data"; then \
			mv -fn $$i `dirname $$i`/`sha256sum $$i | grep -Po '^[a-f0-9]{64}'`.gif; \
		fi \
	done
clean:
	rm -rf public/ resources/
