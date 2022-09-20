
all: basicTrainingGar.gar

basicTrainingGar.gar: 
	gsmake basicTraining_njm.4pw

deploy: basicTrainingGar.gar
	cd distbin && ./deploy.sh

clean:	
	find . -name \*.42? -delete
	rm distbin/*.gar
