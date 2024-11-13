#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <curl/curl.h>

/* Структура для хранения данных, полученных через curl */
struct string {
    char *ptr;
    size_t len;
};

/* Инициализация строки */
void init_string(struct string *s) {
    s->len = 0;
    s->ptr = malloc(s->len + 1);
    if (s->ptr == NULL) {
        fprintf(stderr, "malloc() failed\n");
        exit(EXIT_FAILURE);
    }
    s->ptr[0] = '\0';
}

/* Функция записи данных, полученных curl, в структуру */
size_t writefunc(void *ptr, size_t size, size_t nmemb, struct string *s) {
    size_t new_len = s->len + size * nmemb;
    s->ptr = realloc(s->ptr, new_len + 1);
    if (s->ptr == NULL) {
        fprintf(stderr, "realloc() failed\n");
        exit(EXIT_FAILURE);
    }
    memcpy(s->ptr + s->len, ptr, size * nmemb);
    s->ptr[new_len] = '\0';
    s->len = new_len;
    return size * nmemb;
}

/* Функция для получения стоимости биткоина */
const char *
btc_price(void) {
    CURL *curl;
    CURLcode res;
    static char price_str[32]; // Максимум 32 символа
    struct string s;

    init_string(&s);

    curl = curl_easy_init();
    if (curl) {
        curl_easy_setopt(curl, CURLOPT_URL, "https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=usd");
        curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, writefunc);
        curl_easy_setopt(curl, CURLOPT_WRITEDATA, &s);

        res = curl_easy_perform(curl);

        if (res != CURLE_OK) {
            fprintf(stderr, "curl_easy_perform() failed: %s\n", curl_easy_strerror(res));
        } else {
            char *price_ptr = strstr(s.ptr, "\"usd\":");
            if (price_ptr) {
                sscanf(price_ptr, "\"usd\":%31s", price_str);
                // Удаляем любые нецифровые символы, такие как "}}"
                for (int i = 0; i < strlen(price_str); i++) {
                    if (price_str[i] == '}' || price_str[i] == ',') {
                        price_str[i] = '\0';
                        break;
                    }
                }
            } else {
                strncpy(price_str, "N/A", sizeof(price_str));
            }
        }

        free(s.ptr);
        curl_easy_cleanup(curl);
    } else {
        return NULL;
    }

    return price_str;
}

