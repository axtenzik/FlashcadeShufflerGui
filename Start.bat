SET HOST=127.0.0.1
SET PORT=7070
SET BIZHAWK_PATH=.\

start /B %BIZHAWK_PATH%\\EmuHawk.exe --socket_ip=%HOST% --socket_port=%PORT% --lua=%~dp0FlashcadeShuffler.lua