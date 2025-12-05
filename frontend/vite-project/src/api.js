import axios from "axios";

const API_BASE = "http://127.0.0.1:5000/api";

export const getTransactions = (filters = {}) => {
  return axios.get(`${API_BASE}/transactions`, { params: filters })
    .then(res => res.data);
};

export const createTransaction = (data) => {
  return axios.post(`${API_BASE}/transactions`, data)
    .then(res => res.data);
};

export const updateTransaction = (id, data) => {
  return axios.put(`${API_BASE}/transactions/${id}`, data)
    .then(res => res.data);
};

export const deleteTransaction = (id) => {
  return axios.delete(`${API_BASE}/transactions/${id}`)
    .then(res => res.data);
};
