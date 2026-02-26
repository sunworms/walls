#!/usr/bin/env bash

EXTENSIONS=("jpg" "jpeg" "png" "webp")
SKIP=("docs" "scripts" ".github")
PROCESSED_LOG=".compressed"

# Load already-processed hashes into a set
declare -A processed
if [ -f "$PROCESSED_LOG" ]; then
  while IFS= read -r line; do
    processed["$line"]=1
  done < "$PROCESSED_LOG"
fi

for folder in */; do
  folder="${folder%/}"
  if [[ " ${SKIP[*]} " == *" $folder "* ]]; then
    continue
  fi

  for ext in "${EXTENSIONS[@]}"; do
    for img in "$folder"/*."$ext" "$folder"/*."${ext^^}"; do
      [ -f "$img" ] || continue

      hash=$(md5sum "$img" 2>/dev/null || md5 -q "$img")
      hash="${hash%% *}"  # trim filename from md5sum output

      # Skip if already processed
      if [[ -n "${processed[$hash]}" ]]; then
        echo "Skipping $img (already compressed)"
        continue
      fi

      before=$(stat -c%s "$img" 2>/dev/null || stat -f%z "$img")

      case "${ext,,}" in
        jpg|jpeg)
          magick "$img" -sampling-factor 4:2:0 -strip -quality 85 -interlace Plane "$img"
          ;;
        png)
          pngquant --quality=85-90 --force --output "$img" "$img"
          ;;
        webp)
          magick "$img" -strip -quality 85 "$img"
          ;;
      esac

      # Log the hash of the compressed result
      new_hash=$(md5sum "$img" 2>/dev/null || md5 -q "$img")
      new_hash="${new_hash%% *}"
      echo "$new_hash" >> "$PROCESSED_LOG"
      processed["$new_hash"]=1

      after=$(stat -c%s "$img" 2>/dev/null || stat -f%z "$img")
      saved=$(( (before - after) * 100 / before ))
      echo "$img: ${before} → ${after} bytes (${saved}% smaller)"
    done
  done
done

echo "Done!"
