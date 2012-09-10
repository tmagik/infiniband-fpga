loadProjectFile -file "/tmp/infinibandfpga/Prototyping/RocketIO_Demo_HW/RocketIO_Demo_HW.ipf"
setMode -ss
setMode -sm
setMode -hw140
setMode -spi
setMode -acecf
setMode -acempm
setMode -pff
setMode -bs
setMode -bs
setMode -bs
setMode -bs
Program -p 5 
Program -p 5 
setCable -port auto
Program -p 5 
Program -p 5 
Program -p 5 
saveProjectFile -file "/tmp/infinibandfpga/Prototyping/RocketIO_Demo_HW/RocketIO_Demo_HW.ipf"
setMode -bs
deleteDevice -position 1
deleteDevice -position 1
deleteDevice -position 1
deleteDevice -position 1
deleteDevice -position 1
setMode -ss
setMode -sm
setMode -hw140
setMode -spi
setMode -acecf
setMode -acempm
setMode -pff
setMode -bs
