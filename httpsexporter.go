package main

import (
	"crypto/tls"
	"fmt"
	"io"
	"log"
	"net/http"
	"net/http/httputil"
	"net/url"
	"os"
	"strings"

	auth "github.com/abbot/go-http-auth"

	"github.com/gorilla/context"
	"github.com/keep94/weblogs"
)

func Secret(user, realm string) string {
	if user == "metrics" {
		// password is "hello"
		return "%BASEAUTH%"
	}
	return ""
}

func main() {

	logPath := "/data/gopromexporter.log"

	logFile, err := os.OpenFile(logPath, os.O_CREATE|os.O_APPEND|os.O_RDWR, 0666)
	if err != nil {
		panic(err)
	}
	mw := io.MultiWriter(logFile)
	log.SetOutput(mw)

	fmt.Printf("listening on %v\n", "4443")
	fmt.Printf("Logging to %v\n", logPath)

	director := func(req *http.Request) {

		if strings.Contains(req.URL.Path, "pinger") {
			origin, _ := url.Parse("http://localhost:9374/")
			req.Header.Add("X-Forwarded-Host", req.Host)
			req.Header.Add("X-Origin-Host", origin.Host)
			req.URL.Scheme = "http"
			req.URL.Host = origin.Host
		} else {
			origin, _ := url.Parse("http://localhost:9100/")
			req.Header.Add("X-Forwarded-Host", req.Host)
			req.Header.Add("X-Origin-Host", origin.Host)
			req.URL.Scheme = "http"
			req.URL.Host = origin.Host
		}
	}

	proxy := &httputil.ReverseProxy{Director: director}

	regularHandler := func(w http.ResponseWriter, r *http.Request) {
		proxy.ServeHTTP(w, r)
	}

	authenticator := auth.NewBasicAuthenticator("Local", Secret)

	cfg := &tls.Config{
		MinVersion:               tls.VersionTLS12,
		CurvePreferences:         []tls.CurveID{tls.CurveP384, tls.X25519},
		PreferServerCipherSuites: true,
		InsecureSkipVerify:       true,
		CipherSuites: []uint16{
			tls.TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,
			tls.TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA,
			tls.TLS_RSA_WITH_AES_256_GCM_SHA384,
			tls.TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384,
		},
	}
	loghandler := context.ClearHandler(weblogs.HandlerWithOptions(
		http.DefaultServeMux,
		&weblogs.Options{
			Writer: mw,
			Logger: weblogs.ApacheCombinedLogger(),
		}))

	srv := &http.Server{
		Addr:         ":4443",
		Handler:      loghandler,
		TLSConfig:    cfg,
		TLSNextProto: make(map[string]func(*http.Server, *tls.Conn, http.Handler), 0),
	}

	http.HandleFunc("/", auth.JustCheck(authenticator, regularHandler))

	log.Fatal(srv.ListenAndServeTLS("/data/cert/server.crt", "/data/cert/server.key"))

}
