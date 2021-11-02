#
#
#
PROMUSER=pi
#REV := 2.31.0
REV := 2.22.0
ARCH := armv7
OS := linux
PROMDIR := prometheus-$(REV).$(OS)-$(ARCH)
PROMARCHIVE := prometheus-$(REV).$(OS)-$(ARCH).tar.gz
ESCAPED_FULLPATH := $(shell echo $(PWD)/$(PROMDIR) | sed 's/\//\\\//g')

NODEEXPREV := 1.2.2
NODEEXPDIR := node_exporter-$(NODEEXPREV).linux-$(ARCH)
NODEEXPARCHIVE := node_exporter-$(NODEEXPREV).linux-$(ARCH).tar.gz
NODEEXP_ESCAPED_FULLPATH := $(shell echo $(PWD)/$(NODEEXPDIR) | sed 's/\//\\\//g')

zyzygy: wget xzvpf install start

wget:
	wget https://github.com/prometheus/prometheus/releases/download/v$(REV)/$(PROMARCHIVE)
	wget https://github.com/prometheus/node_exporter/releases/download/v$(NODEEXPREV)/$(NODEEXPARCHIVE)

localize:
	sed "s/NODEEXPDIR/$(NODEEXP_ESCAPED_FULLPATH)/g" node_exporter.service.dist > node_exporter.service
	sed -i 's/PROMUSER/$(PROMUSER)/g' node_exporter.service
	sed "s/PROMDIR/$(ESCAPED_FULLPATH)/g" prometheus.service.dist > prometheus.service
	sed -i 's/PROMUSER/$(PROMUSER)/g' prometheus.service

xzvpf:
	tar xzvpf $(PROMARCHIVE)
	tar xzvpf $(NODEEXPARCHIVE)

enable: cp-systemd
	sudo systemctl enable prometheus
	sudo systemctl enable node_exporter

disable: stop
	sudo systemctl disable prometheus
	sudo systemctl disable node_exporter

start:
	sudo systemctl start prometheus
	sudo systemctl start node_exporter

stop:
	- sudo systemctl stop prometheus
	- sudo systemctl stop node_exporter

install: cp-systemd enable start

uninstall: disable rm-systemd

realclean: clean
	rm -rf $(PROMDIR)

clean:
	rm $(NODEEXPARCHIVE)
	rm $(PROMARCHIVE)

cp-systemd: localize
	sudo cp prometheus.service /etc/systemd/system/
	sudo cp node_exporter.service /etc/systemd/system/

rm-systemd:
	sudo rm /etc/systemd/system/prometheus.service
	sudo rm /etc/systemd/system/node_exporter.service

