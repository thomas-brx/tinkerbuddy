# tinkerbuddy
Run Tinkerwell on Kubernetes pods

According to Tinkerwell, running on a pod in Kubernetes is [currently not possible](https://tinkerwell.app/docs/3/setup-guides/docker#kubernetes-and-docker-on-remote-servers).

Since Tinkerwell has support for local Docker, I figured that could be exploited.

Technically what Tinkerwell does is this:
```
docker cp tinker.phar <container>:/tmp/tinker.phar
docker cp tinker_data.txt <container>:/tmp/tinker_data.txt                       # Contains the PHP-code from the Tinkerwell GUI
docker exec <container> php /tmp/tinker.phar cli data=/tmp/tinker_data.txt ..... # Executes the PHP-code in the container
```

The result from the last command is the json-encoded output of the script. This is then presented in Tinkerwell.

I ended up creating a Docker containear `tinkerbuddy`. This tinkerbuddy container can be connected to a shell in any php environment by cross-wiring stdin and stdout. This can be over ssh, or kubectl exec for example, or a chain of those, like we have in our jumphost setup.
tinkerbuddy has a custom php installed, a simple script. This php will intercept the docker exec above, and will trigger a chain of events:

```
1) If tinker.phar has not been copied, copy to the connected environment (sent as a base64-encoded HERE-doc)
2) Copy the tinker_data.txt as a base64-encoded HERE-doc
3) Run the php /tmp/tinker.phar on the connected environment
4) Read result and send back
```

The bash script `tinkerbuddy` is an example helper script to get the cross-wiring required between docker and the remote process.
