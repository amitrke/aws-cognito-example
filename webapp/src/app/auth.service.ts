import { Injectable } from '@angular/core';
import { AuthTokens, AuthUser, fetchAuthSession, getCurrentUser, signOut } from 'aws-amplify/auth';

@Injectable({
  providedIn: 'root'
})
export class AuthService {

  constructor() { }

  async getCurrentUser(): Promise<AuthUser> {
    return await getCurrentUser();
  }

  async getCurrentSession(): Promise<AuthTokens | undefined> {
    return (await fetchAuthSession()).tokens;
  }

  async getCurrentUserFullName(): Promise<string | undefined> {
    let cognitoToken = await (await fetchAuthSession()).tokens;
    return cognitoToken?.idToken?.payload['name']?.toString();
  }

  async getIDToken(): Promise<string | undefined> {
    return (await fetchAuthSession()).tokens?.idToken?.toString();
  }

  async getUserInfo(): Promise<User | undefined> {
    return (await fetchAuthSession()).tokens?.idToken?.payload as User;
  }

  signOut() {
    signOut();
  }
}

export type User = {
  username: string,
  email: string,
  name: string,
  family_name: string,
  given_name: string,
  email_verified: boolean,
  sub: string
}