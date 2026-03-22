import { makeAutoObservable } from 'mobx';

export class UIStore {
  sidebarOpen = true;
  globalLoading = false;

  constructor() {
    makeAutoObservable(this);
  }

  toggleSidebar() {
    this.sidebarOpen = !this.sidebarOpen;
  }

  setSidebarOpen(open: boolean) {
    this.sidebarOpen = open;
  }
}
