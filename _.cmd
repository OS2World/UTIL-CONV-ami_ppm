@echo off
call stampdef ami_ppm.def
call pasvpdsp ami_ppm ami_ppm.vk\
copy ami_ppm.vk\ami_ppm.exe ami_ppm.vk\ami_ppm.com
call copywdx ami_ppm.vk\
call pasvpo ami_ppm ami_ppm.vk\

call ..\genvk ami_ppm

cd ami_ppm.vk
call genpgp
cd ..


