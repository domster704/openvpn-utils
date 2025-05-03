# Openvpn utils

Этот репозиторий содержит скрипты для управления клиентами OpenVPN на вашем сервере. Скрипты автоматизируют создание, удаление и мониторинг VPN-клиентов.

## Содержание

- [Требования](#требования)  
- [Установка](#установка)  
- [addClient.sh](#addclientsh)  
- [delClient.sh](#delclientsh)  
- [monitor.sh](#monitorsh) 

## Требования

- CA и OpenVPN сервер находятся на одном сервере
- Сервер с установленным OpenVPN и Easy-RSA  
- Права `sudo` для пользователя `admin`  
- Директория пользователя `admin`: `/home/admin`  
- Пути к Easy-RSA:  
  - Серверная часть: `/home/admin/easy-rsa-server`  
  - CA: `/home/admin/easy-rsa`  

## Установка

1. Склонируйте репозиторий:
   ```bash
   git clone https://your-repo-url.git ~
   cd ~
   ```
2. Сделайте скрипты исполняемыми:
   ```bash
   chmod +x addClient.sh delClient.sh monitor.sh
   ```

## addClient.sh

Скрипт автоматизирует генерацию, подписание и сборку конфигурационного файла `.ovpn` для нового клиента.

```bash
./addClient.sh <clientName>
```

### Как работает

1. **Удаление старых сертификатов**  
   Запускает `delClient.sh` для удаления старых файлов клиента.  
2. **Генерация запроса**  
   ```bash
   cd /home/admin/easy-rsa-server
   ./easyrsa gen-req "<clientName>" nopass
   ```
3. **Копирование ключа**  
   ```bash
   sudo cp pki/private/<clientName>.key /home/admin/client-configs/keys/
   ```
4. **Импорт запроса в CA**  
   ```bash
   cd ~/easy-rsa
   sudo ./easyrsa import-req /home/admin/easy-rsa-server/pki/reqs/<clientName>.req <clientName>
   ```
5. **Подписание сертификата**  
   ```bash
   sudo ./easyrsa sign-req client <clientName>
   ```
6. **Копирование сертификата**  
   ```bash
   sudo cp pki/issued/<clientName>.crt /home/admin/client-configs/keys/
   ```
7. **Генерация `.ovpn`**  
   ```bash
   cd ~/client-configs
   bash make_config.sh <clientName>
   ```
8. **Готово**  
   Конфигурация в `/home/admin/client-configs/files/<clientName>.ovpn`

## delClient.sh

Скрипт отзывает сертификат, обновляет CRL и удаляет файлы клиента.

```bash
./delClient.sh <clientName>
```

1. **Поиск файлов**  
2. **Подтверждение удаления**  
3. **Отзыв и генерация CRL**  
   ```bash
   easyrsa revoke <clientName>
   easyrsa gen-crl
   sudo cp easy-rsa/pki/crl.pem /etc/openvpn/server/
   ```
4. **Удаление и рестарт**  
   ```bash
   sudo find ~ -name "<clientName>*" -delete
   sudo systemctl restart openvpn-server@server.service
   ```

## monitor.sh

Мониторинг активных клиентов:

```bash
./monitor.sh
```

- Обновление каждые 1 секунду (`watch -n 1`)  
- Чтение `/var/log/openvpn/openvpn-status.log`  
- Вывод списка клиентов с IP, трафиком, временем и шифром  
