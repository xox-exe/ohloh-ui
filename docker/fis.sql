update pg_database set encoding = pg_char_to_encoding('SQL_ASCII'), datcollate = 'en_US.UTF8', datctype = 'en_US.UTF8' where datname = 'template0';

CREATE USER openhub_user SUPERUSER;
ALTER USER openhub_user WITH PASSWORD 'openhub_password';
