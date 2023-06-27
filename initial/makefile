
WSSRV=http://localhost:8080

export FGLRESOURCEPATH=$(PWD)/etc
export FGLLDPATH=$(PWD)/bin:$(GREDIR)/lib:$(FGLDIR)/testing_utilities/ggc/lib
export DBNAME=$(PWD)/etc/training.db

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

run: 
	cd bin && fglrun menu M menu_sg
