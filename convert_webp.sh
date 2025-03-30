#!/bin/bash

# 기본값 설정
WIDTH=200
HEIGHT=200

# 입력값이 있으면 사용
if [ $# -eq 2 ]; then
    WIDTH=$1
    HEIGHT=$2
elif [ $# -ne 0 ]; then
    echo "사용법: $0 [너비] [높이]"
    echo "입력이 없으면 기본값 ${WIDTH}x${HEIGHT}을 사용합니다."
    echo "예시: $0 300 300"
    exit 1
fi

echo "이미지 크기: ${WIDTH}x${HEIGHT}로 변환합니다."

# cwebp 명령어 존재하는지 확인
if ! command -v cwebp &> /dev/null; then
    echo "cwebp 명령이 설치되어 있지 않습니다."
    echo "Ubuntu/Debian: sudo apt-get install webp"
    echo "macOS: brew install webp"
    exit 1
fi

# 일반적인 이미지 파일 확장자들
IMAGE_EXTENSIONS=("jpg" "jpeg" "png" "tiff" "gif" "bmp")

# 변환 카운터
CONVERTED=0
FAILED=0

# 각 확장자별로 이미지 파일 처리
for EXT in "${IMAGE_EXTENSIONS[@]}"; do
    # 대소문자 구분 없이 확장자 검색
    for IMG in *.$EXT *.$EXT.[jJ][pP][gG] *.$EXT.[jJ][pP][eE][gG] *.$EXT.[pP][nN][gG]; do
        # 파일이 실제로 존재하는지 확인 (와일드카드 매치가 없을 경우 대비)
        if [[ -f "$IMG" && "$IMG" != "*.$EXT" && "$IMG" != "*.$EXT.[jJ][pP][gG]" && "$IMG" != "*.$EXT.[jJ][pP][eE][gG]" && "$IMG" != "*.$EXT.[pP][nN][gG]" ]]; then
            # 파일 이름에서 확장자 제거
            FILENAME=$(basename -- "$IMG")
            FILENAME="${FILENAME%.*}"
            
            echo "변환 중: $IMG -> $FILENAME.webp"
            
            # cwebp로 변환 실행
            if cwebp -q 80 -resize $WIDTH $HEIGHT "$IMG" -o "$FILENAME.webp"; then
                echo "변환 성공: $FILENAME.webp"
                # 원본 파일 삭제
                rm "$IMG"
                echo "원본 파일 삭제: $IMG"
                ((CONVERTED++))
            else
                echo "변환 실패: $IMG"
                ((FAILED++))
            fi
        fi
    done
done

echo "작업 완료: $CONVERTED 파일 변환됨, $FAILED 파일 실패"

# 결과가 없을 경우
if [ $CONVERTED -eq 0 ] && [ $FAILED -eq 0 ]; then
    echo "현재 폴더에 변환할 이미지 파일이 없습니다."
fi