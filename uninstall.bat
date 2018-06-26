@echo "Clearing Environment Params......"

@echo "Clearing Enviroment Variables"
@setx RD_ROOT_DIR    ""
@setx RD_SERVER_IP   ""
@setx RD_SERVER_PORT ""
@setx LUA_INIT       ""
@setx LUA_EXE        ""
@setx RD_CLIENT_IP   ""
@setx RD_CLIENT_PORT ""

@echo "Clearing AutoRun Register"
@reg delete "hkcu\software\microsoft\command processor" /v Autorun /ve /f

if exists "%ROOT_DIR%script/rd_server.vbs" (
    @echo "Clearing Timing Task"
    @start_file=%ROOT_DIR%script/rd_server.vbs
    @schtasks /delete /tn rmd
    @del %start_file%
)

@echo "Uninstall Success"
