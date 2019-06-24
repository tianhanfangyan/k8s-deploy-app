package main

import "github.com/kataras/iris"

func main()  {
	app := iris.New()

	app.Get("/", func(ctx iris.Context) {
		ctx.WriteString("deploy a golang web app")
	})

	app.Run(iris.Addr("localhost:8000"), iris.WithoutServerError(iris.ErrServerClosed))

}