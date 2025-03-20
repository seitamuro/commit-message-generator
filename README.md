## 生成されたコミットメッセージをそのまま利用する

```
git commit -m "$(echo -e "$(bash generate_commit_message.sh)" | tr -d '"')"
```
