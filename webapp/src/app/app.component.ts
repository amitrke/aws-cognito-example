import { Component } from '@angular/core';
import { Hub } from 'aws-amplify/utils';
import { getCurrentUser, fetchAuthSession } from 'aws-amplify/auth';
import { AuthService } from './auth.service';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrl: './app.component.scss'
})
export class AppComponent {
  title = 'webapp';

  constructor(private authService: AuthService) {}

  async ngOnInit() {
    const session = await fetchAuthSession();
    console.log("id token", session.tokens?.idToken?.toString());
  }
}