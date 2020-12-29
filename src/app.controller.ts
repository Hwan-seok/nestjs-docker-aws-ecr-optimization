import { Controller, Get } from '@nestjs/common';
import { AppService } from './app.service';

@Controller()
export class AppController {
  a = 0;
  constructor(private readonly appService: AppService) {}

  @Get()
  getHello(): string {
    console.log(this.a++);
    return this.appService.getHello() + process.env.NODE_ENV;
  }
}
