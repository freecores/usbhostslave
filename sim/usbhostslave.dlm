<?xml version="1.0" encoding="UTF-8"?>
<CONFIG>
 <Version>
  <version number="3"/>
 </Version>
 <Compilation>
  <folder name="$ALDEC\SYSTEMC\interface"/>
  <folder name="$ALDEC\mingw\include"/>
  <folder name="$dsn\bench"/>
  <file name="$dsn\bench\usbHostSlaveTB.cpp"/>
  <file name="$dsn\bench\testwrapper.cpp"/>
  <file name="$dsn\bench\transactor.cpp"/>
  <options name="-ggdb"/>
  <options name="-shared"/>
  <options name="-Wno-deprecated"/>
  <options name="-fno-strict-aliasing"/>
  <options name="-fno-gcse-lm"/>
  <options name="-D__int64=&quot;long"/>
  <options name="long"/>
  <options name="int&quot;"/>
 </Compilation>
 <Linker>
  <target name="$dsn\usbhostslave.dll"/>
  <library name="$ALDEC\SYSTEMC\interface\systemc.def"/>
  <library name="$ALDEC\SYSTEMC\lib\Systemc.a"/>
  <library name="$ALDEC\mingw\lib\libstdc++.a"/>
  <options name="-shared"/>
  <folder name="$ALDEC\SYSTEMC\lib"/>
  <folder name="$ALDEC\mingw\lib"/>
 </Linker>
 <Type>
  <DesignType name="SYSTEMC"/>
 </Type>
 <Additional>
  <AddLibraryToDesign name="false"/>
  <AddModulesToLibrary name="true"/>
 </Additional>
</CONFIG>
