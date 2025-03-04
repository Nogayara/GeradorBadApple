@echo off
setlocal enabledelayedexpansion
title Gerador de Bad Apple

:: Solicitar arquivos em sequencia
echo Arraste o video monocromatico Bad Apple e pressione Enter:
set /p "input_video="
set "input_video=%input_video:~1,-1%"
if not exist "%input_video%" (
    echo Erro: O arquivo especificado nao existe.
    pause
    exit /b
)
ren "%input_video%" "bad_apple.mp4"
set "input_video=bad_apple.mp4"

echo.
echo Arraste uma imagem que deseja ser a parte branca do video e pressione Enter:
set /p "input_white="
set "input_white=%input_white:~1,-1%"
if not exist "%input_white%" (
    echo Erro: O arquivo especificado nao existe.
    pause
    exit /b
)
ren "%input_white%" "white_image.png"
set "input_white=white_image.png"

echo.
echo Arraste uma imagem que deseja ser a parte preta do video e pressione Enter:
set /p "input_black="
set "input_black=%input_black:~1,-1%"
if not exist "%input_black%" (
    echo Erro: O arquivo especificado nao existe.
    pause
    exit /b
)
ren "%input_black%" "black_image.png"
set "input_black=black_image.png"

echo Processando o video...

:: Definir os arquivos de saida
set "output_video=resultado.mp4"

:: Converter as imagens para 480x360, se necessario
ffmpeg -i "%input_white%" -vf "scale=480:360" "white_resized.png"
ffmpeg -i "%input_black%" -vf "scale=480:360" "black_resized.png"

:: Executar a conversao para gerar o video
ffmpeg -i "%input_video%" -i "white_resized.png" -i "black_resized.png" -filter_complex "[0:v]format=gray,scale=480:360[mask];[mask]split=2[mask_white][mask_black];[mask_white]boxblur=2,lutrgb=r='if(eq(val,255),255,0)':g='if(eq(val,255),255,0)':b='if(eq(val,255),255,0)'[white_mask];[mask_black]boxblur=2,lutrgb=r='if(eq(val,0),255,0)':g='if(eq(val,0),255,0)':b='if(eq(val,0),255,0)'[black_mask];[1:v]scale=480:360[white];[2:v]scale=480:360[black];[white][white_mask]alphamerge[white_layer];[black][black_mask]alphamerge[black_layer];[white_layer][black_layer]overlay=shortest=1,scale=480:360[out]" -map "[out]" -map 0:a:0 -c:v libx264 -pix_fmt yuv420p -c:a aac -b:a 128k "%output_video%"

:: Deletar os arquivos temporarios de imagens redimensionadas
del "white_resized.png"
del "black_resized.png"

:: Reproduzir o video final
start "" "%output_video%"

echo Processo concluido! O arquivo esta salvo como %output_video%.
pause