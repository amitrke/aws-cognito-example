import { Component } from '@angular/core';
import { fetchAuthSession } from 'aws-amplify/auth';
import { AuthService, User } from './auth.service';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrl: './app.component.scss'
})
export class AppComponent {
  title = 'webapp';
  userInfo: User | undefined;

  constructor(private authService: AuthService) {}

  async ngOnInit() {
    const userInfo = await this.authService.getUserInfo();
    this.userInfo = userInfo;
  }

  async signOut() {
    await this.authService.signOut();
  }
}