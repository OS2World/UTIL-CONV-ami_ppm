@echo off
for %%d in (*.ppm) do del %%d
for %%d in (*.grf) do ..\ami_ppm.vk\ami_ppm.exe %%d
call pmview *.ppm
for %%d in (*.ppm) do del %%d