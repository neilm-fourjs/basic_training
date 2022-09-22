
WSSRV=http://localhost:8080

all: src/ws_clistk.4gl basicTrainingGar.gar

basicTrainingGar.gar: 
	gsmake basicTraining_njm.4pw

deploy: basicTrainingGar.gar
	cd distbin && ./deploy.sh

clean:	
	find . -name \*.42? -delete
	rm distbin/*.gar

src/ws_clistk.4gl:
	fglrestful -o $@ $(WSSRV)/stk?openapi.json
