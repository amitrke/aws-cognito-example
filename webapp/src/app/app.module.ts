import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';

import { AppRoutingModule } from './app-routing.module';
import { AppComponent } from './app.component';
import { Amplify } from 'aws-amplify';
import { AmplifyAuthenticatorModule } from '@aws-amplify/ui-angular';
import awsconfig from './aws-exports';
import { provideAnimationsAsync } from '@angular/platform-browser/animations/async';
import { MatIconModule } from '@angular/material/icon';
import { MatButtonModule } from '@angular/material/button';
import { MatToolbarModule } from '@angular/material/toolbar';
import { EventsComponent } from './events/events.component';
import { MatDatepickerModule } from '@angular/material/datepicker';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatCardModule } from '@angular/material/card';
import { ReactiveFormsModule } from '@angular/forms';
import { MatNativeDateModule } from '@angular/material/core';
import { MatInputModule } from '@angular/material/input';
import { MatOptionModule } from '@angular/material/core';
import { MatSelectModule } from '@angular/material/select';
import { provideHttpClient, withFetch } from '@angular/common/http';

Amplify.configure(awsconfig);

@NgModule({
  declarations: [
    AppComponent,
    EventsComponent
  ],
  imports: [
    BrowserModule,
    AppRoutingModule,
    AmplifyAuthenticatorModule,
    MatToolbarModule, 
    MatButtonModule, 
    MatIconModule,
    MatDatepickerModule,
    MatFormFieldModule,
    MatCardModule,
    ReactiveFormsModule,
    MatNativeDateModule,
    MatInputModule,
    MatOptionModule,
    MatSelectModule
  ],
  providers: [
    provideAnimationsAsync(),
    provideHttpClient(
      withFetch()
    ),
  ],
  bootstrap: [AppComponent]
})
export class AppModule { }
