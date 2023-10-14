NETNS_NAME=tofu

tests:
	coverage run --omit='test_*.py,__init__.py' -m unittest discover
	coverage report -m

test_container:
	coverage run --omit='test_*.py,__init__.py' -m unittest -k container
	coverage report -m diyns/container.py

kill_tests:
	ps --no-headers -C sleep -o pid | xargs -I{} kill -9 {}
	ip netns delete $(NETNS_NAME) || true
