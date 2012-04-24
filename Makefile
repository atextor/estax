ESTAX=estax
XALANPATH=./estax
CLASSPATH=$(XALANPATH)/xalan.jar:$(XALANPATH)/xml-apis.jar:$(XALANPATH)/xercesImpl.jar
JAVA=java
XALAN=org.apache.xalan.xslt.Process
SITE=$(ESTAX)/estax.xsl
XMLFILES=$(wildcard *.xml)
NAMES=$(patsubst %.xml,%,$(XMLFILES))

default: all
	
all: $(XMLFILES)
ifeq ($(XMLFILES),)
	@echo "No XML files found. Please create a content XML, then run make again."
else
	-make $(NAMES)
endif

%: %.xml
	-rm -rf "$@"
	-mkdir -p "$@"
	$(JAVA) -cp $(CLASSPATH) $(XALAN) -in $< -xsl $(SITE) -param outdir $@ &>/dev/null
ifneq ($(wildcard *.css),)
	cp  *.css "$@"
endif
ifneq ($(wildcard *.js),)
	cp  *.js "$@"
endif
