package logging

import (
	"os"

	"github.com/sirupsen/logrus"
)

type Logger = logrus.Logger

func Init(debug bool) {
	logrus.SetOutput(os.Stdout)
	if debug {
		logrus.SetLevel(logrus.DebugLevel)
	} else {
		logrus.SetLevel(logrus.InfoLevel)
	}
	logrus.SetFormatter(&logrus.TextFormatter{
		FullTimestamp: true,
	})
}

func GetLogger() Logger {
	return *logrus.StandardLogger()
}
