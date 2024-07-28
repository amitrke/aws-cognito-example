import { Component } from '@angular/core';
import { Hub } from 'aws-amplify/utils';
import { getCurrentUser, fetchAuthSession } from 'aws-amplify/auth';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrl: './app.component.scss'
})
export class AppComponent {
  title = 'webapp';

  ngOnInit() {
    Hub.listen('auth', async (data) => {
      console.log(data)
      if (data.payload.event === 'signedIn') {
        const { username, userId, signInDetails } = await getCurrentUser();
        console.log("username", username);
        console.log("user id", userId);
        console.log("sign-in details", signInDetails);

        const session = await fetchAuthSession();
        console.log("session", session);
      }
    });
  }
}