```
	"derpMap": {
		"OmitDefaultRegions": true, // 可以设置为 true，这样不会下发官方的 derper 节点，测试或者实际使用都可以考虑打开
		"Regions": {
			"900": {
				"RegionID":   900, // tailscale 900-999 是保留给自定义 derper 的
				"RegionCode": "cmi",
				"RegionName": "Hong Kong", // 这俩随便命名
				"Nodes": [
					{
						"Name":             "VPS-Name",
						"RegionID":         900,
						"IPv4":             "Your IP", // 你的VPS 公网IP地址
						"STUNPort":         3478,
						"DERPPort":         Port, //上面 12345 你自定义的端口
						"InsecureForTests": true, // 因为是自签名证书，所以客户端不做校验
					},
				],
			},
		},
	},
```
