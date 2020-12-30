import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  console.log(process.env.NODE_ENV);
  console.log(process.env.NODE_ENV);
  console.log(process.env.NODE_ENV);
  console.log(11);
  await app.listen(40001331);
}
bootstrap();
